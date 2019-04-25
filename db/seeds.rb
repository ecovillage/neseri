# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).

User.create!([
  {email: 'user@neseri.tu',  password: 'userneseritu',  password_confirmation: 'userneseritu', tos_agreement: true },
  {email: 'admin@neseri.tu', password: 'adminneseritu', password_confirmation: 'adminneseritu', tos_agreement: true},
  ])

User.find_each do |user|
  user.confirm
end

SeminarKind.create!([
  { name: 'Wochenende' },
  { name: 'In der Woche' },
  { name: 'Tagesveranstaltung' }
  ])

