# frozen_string_literal: true

module Pipedrive
  class Lead < Resource
    include Fields

    update_method :patch

  end
end
