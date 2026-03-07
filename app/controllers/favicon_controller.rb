class FaviconController < ApplicationController
  allow_unauthenticated_access

  def show
    theme_colors = if authenticated? && current_user.theme.present?
      ApplicationHelper::THEME_COLORS[current_user.theme] || ApplicationHelper::THEME_COLORS["default"]
    else
      ApplicationHelper::THEME_COLORS["default"]
    end

    bg_color = theme_colors[:primary]
    text_color = theme_colors[:text]

    svg = <<~SVG
      <svg width="512" height="512" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
        <rect width="512" height="512" rx="96" fill="#{bg_color}"/>
        <text x="256" y="340" font-family="Arial Black, Arial, sans-serif" font-size="280" font-weight="900" font-style="italic" fill="#{text_color}" text-anchor="middle" transform="skewX(-12)">FS</text>
      </svg>
    SVG

    response.headers["Cache-Control"] = "private, max-age=3600"
    render inline: svg, content_type: "image/svg+xml"
  end
end
