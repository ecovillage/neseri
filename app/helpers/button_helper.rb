module ButtonHelper
  def button_link_to  icon, path, text, bulma_classes, **kw
    link_to(path, class: 'button ' + bulma_classes, **kw) do
      content_tag("span", class: 'icon ' + bulma_classes) do
        content_tag("i", class: "fa %s" % icon) do
        end
      end + content_tag("span") do
        text
      end
    end
  end
end
