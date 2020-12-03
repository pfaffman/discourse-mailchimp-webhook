# name: discourse-mailchimp-webhook
# version: 0.2
# authors: Jay Pfaffman (jay@literatecomputing.com), Angus McLeod and HappyPorch

PLUGIN_NAME = 'discourse_mailchimp_webhook'.freeze

enabled_site_setting :discourse_mailchimp_webhook_enabled


after_initialize do
  register_seedfu_fixtures(Rails.root.join("plugins", "discourse-mailchimp-webhook", "db", "fixtures").to_s)

  load File.expand_path('../serializers/mailchimp_serializer.rb', __FILE__)

  DiscourseEvent.on(:user_created) do |user|
    WebHook.enqueue_object_hooks(:user_created, user, 'user_created', MailchimpSerializer)
  end

  DiscourseEvent.on(:user_approved) do |user|
    WebHook.enqueue_object_hooks(:user_approved, user, 'user_approved', MailchimpSerializer)
  end

  Plugin::Filter.register(:after_build_web_hook_body) do |context, body|
    if body['user_created']
      body['user_created'].each do |param, value|
        body[param] = value
      end
    end

    if body['user_approved']
      body['user_approved'].each do |param, value|
        body[param] = value
      end
    end
    
    body
  end
end
