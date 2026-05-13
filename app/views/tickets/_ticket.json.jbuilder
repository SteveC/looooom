json.extract! ticket, :id, :user_id, :title, :description, :status, :priority, :created_at, :updated_at
json.url ticket_url(ticket, format: :json)
