class BulmaDoubleFormBuilder< BulmaFormBuilder::HorizontalBulmaFormBuilder
  delegate :content_tag, :tag, to: :@template

  def user_seminar_value attr_name
    object&.user_seminar&.send(attr_name)
  end

  def labeled_columns attr_name, cell1, cell2
    div_with_class('columns is-multiline') do
      div_with_class('column is-2') do
        label(attr_name, class: 'label')
      end + div_with_class('column is-5') do
        cell1.call
      end + div_with_class('column is-5') do
        cell2.call
      end
    end
  end

  def double_text_input attr_name, classes: ''
    labeled_columns attr_name,
      ->{ text_field attr_name, class: join_classes('input', classes)  },
      ->{ @template.text_field_tag :no_op, user_seminar_value(attr_name), class: 'input disabled', disabled: true }
  end

  def double_text_area attr_name, classes: '', size: 5
    labeled_columns attr_name,
      ->{ text_area attr_name, class: join_classes('input textarea', classes) , size: "10x#{size}" },
      ->{ @template.text_area_tag :no_op, user_seminar_value(attr_name), class: 'input textarea disabled', disabled: true, size: "10x#{size}" }
  end

  def double_datetime_select attr_name
    # TODO move this into bulmaformbuilder
    dt_select = ->{ date_time_selector = ActionView::Helpers::DateTimeSelector.new(object&.send(attr_name),
                                                                     { prefix: object.model_name.param_key,
                                                                       include_position: true,
                                                                       field_name: attr_name.to_s})
      @template.concat(div_with_class("select") { date_time_selector.select_year })
      @template.concat(" ")
      @template.concat(div_with_class("select") { date_time_selector.select_month })
      @template.concat(" ")
      @template.concat(div_with_class("select") { date_time_selector.select_day })
      @template.concat(" ")
      @template.concat(div_with_class("select") { date_time_selector.select_hour })
      @template.concat(content_tag :span, " : ")
      @template.concat(div_with_class("select") { date_time_selector.select_minute })
    }

    labeled_columns attr_name,
      dt_select,
      ->{ content_tag 'i', I18n.l(user_seminar_value(attr_name)) }
  end

  def double_select attr_name, collection, value_func, display_func
    labeled_columns attr_name,
      -> { collection_select(attr_name, collection, value_func, display_func, class: 'input select') },
      -> { content_tag 'i', user_seminar_value(attr_name).to_s}
  end

  def double_number_field attr_name, classes: ''
    labeled_columns attr_name,
      -> { number_field attr_name, class: join_classes('input', classes) },
      -> { content_tag 'i', user_seminar_value(attr_name) }
  end

  private def join_classes base_class='', classes=''
    "#{base_class} #{classes}".strip
  end
end
