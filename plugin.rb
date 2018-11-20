# name: discourse-mailchimp-webhook
# version: 0.1
# authors: Jay Pfaffman (jay@literatecomputing.com)

PLUGIN_NAME = 'discourse_mailchimp_webhook'.freeze

enabled_site_setting :discourse_mailchimp_webhook_enabled

after_initialize do
  register_seedfu_fixtures(Rails.root.join('plugins',
                                           'discourse-mailchimp-webhook',
                                           'db', 'fixtures').to_s)

  DiscourseEvent.on(:user_created) do |user|
    WebHook.enqueue_object_hooks(:user, user, 'user_created')

    add_model_callback(:notification, :after_commit, on: :create) do
      # you can enqueue web hooks anywhere outside the AR transaction
      # provided that web hook event type exists
      WebHook.enqueue_hooks(:notification, # event type name
                            notification_id: id, # pass the relevant record id
                            # event name appears in the header of webhook payload
                            event_name: "notification_#{Notification.types[notification_type]}_created")
    end

    %i[user_created].each do |event|
      DiscourseEvent.on(event) do |user|
        WebHook.enqueue_hooks(:session, user_id: user.id, event_name: event.to_s)
      end
    end

    Jobs::EmitWebHookEvent.class_eval do
      # the method name should always be setup_<event type name>(args)
      def setup_notification(args)
        notification = Notification.find_by(id: args[:notification_id])
        return if notification.blank? # or raise an exception if you like

        # here you can define the serializer, you can also create a new serializer to prune the payload
        # See also: `WebHookPostSerializer`, `WebHookTopicViewSerializer`
        args[:payload] = NotificationSerializer.new(notification, scope: guardian, root: false).as_json
      end

      def setup_session(args)
        user = User.find_by(id: args[:user_id])
        return if user.blank?
        args[:payload] = UserSerializer.new(user, scope: guardian, root: false).as_json
      end
    end

    Plugin::Filter.register(:after_build_web_hook_body) do |_instance, body|
      puts "BODY! #{body}"
      # {
      #     "email_address": "urist.mcvankab@freddiesjokes.com",
      #     "status": "subscribed",
      #     "merge_fields": {
      #         "FNAME": "Urist",
      #         "LNAME": "McVankab"
      #     }
      # }
      body[:user_session] = body.delete :session if body[:session]
      body = "test asdf"

      body # remember to return the object, otherwise the payload would be empty
    end
  end

end