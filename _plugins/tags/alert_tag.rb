require 'action_view'

module Shipyard
  module Jekyll
    class Alert < Liquid::Block
      include ActionView::Context
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::TextHelper

      def flash_alert(*args, &block)
        alert_txt = ''
        alert_txt = capture(&block) if block_given?
        options = {}
        options[:role] ||= 'alert'
        class_list = ['alert']
        dismissible = false

        args.each do |arg|
          if arg == :dismissible
            dismissible = true
            options[:shipyard] = 'alert'
          elsif arg.is_a? Symbol
            class_list << "alert-#{alert_type(arg)}"
          elsif arg.is_a? Hash
            options = options.merge(arg) if arg.is_a?(Hash)
          else
            alert_txt = arg
          end
        end

        options[:class] = "#{class_list.join(' ')} #{options[:class]}".strip

        content_tag :div, options do
          concat content_tag(:p, raw(alert_txt), class: 'alert-txt')
          if dismissible
            concat content_tag(:button,
                     icon(:x, class: 'alert-close-icon icon-outline-inverse center'),
                     class: 'alert-close center-v',
                     shipyard: 'alert-close'
                   )
          end
        end
      end

      def icon(icon, attrs = {})
        ''
      end

      def initialize(tag_name, params, options)
        super
        @params = params.strip.split(',').map(&:strip)
        @args = []
        @params.each do |param|
          if param.start_with?(':')
            @args << param.tr(':','').to_sym
          else
            @args << eval("{#{param}}")
          end
        end
      end

      def render(context)
        flash_alert(*@args, super)
      end

      private

      def alert_type(type)
        case type.to_sym
        when :notice then :success
        when :alert then :error
        else type.to_s.tr('_', '-')
        end
      end
    end
  end
end

Liquid::Template.register_tag('alert', Shipyard::Jekyll::Alert)
