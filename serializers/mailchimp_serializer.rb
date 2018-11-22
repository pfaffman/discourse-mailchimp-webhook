class MailchimpSerializer < ApplicationSerializer
  attributes :email_address, :status, :merge_fields

  def email_address
    object.email
  end

  def status
    'subscribed'
  end

  def merge_fields
    fields = Hash.new
    fields["FNAME"] = object.name if object.name.present?
    fields
  end
end
