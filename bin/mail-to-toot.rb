#!/usr/bin/env ruby
# frozen_string_literal: true

# Copyright 2023 Keith T. Garner
#
# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the
# following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following
#    disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following
#    disclaimer in the documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote
#    products derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES,
# INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"
require "dotenv/load"
require "mail"
require "httparty"
require "json"
require "securerandom"

OPENINGS = [
  "I'm back on my bike bullshit again.",
  "Time to burn the calories...",
  "These messages are random to not annoy you with the same thing each time I ride.",
  "Ride ride ride my bike, gently down the street.",
  "IT'S HAPPENING!",
  "Holy Pedal Power, Batman!",
  "I'm on my bike, and I'm ready to ride!",
  "And miles to go before I sleep...",
  "<insert your meme here>"
].freeze

inbound = $stdin.read
mail = Mail.read_from_string(inbound)

text = mail.parts.find { |p| p.mime_type == "text/plain" }
url = URI.extract(text.decode_body, /http(s)?/).find { |u| u.include?("/users/live/") }

headers = {
  "Authorization" => "Bearer #{ENV.fetch('ACCESS_TOKEN', nil)}",
  "Content-Type" => "application/json",
  "Idempotency-Key" => SecureRandom.uuid
}

status = <<~MESSAGE
  #{OPENINGS.sample}

  Follow me as I ride at #{url}

  #auto-post #biking #wahooligan #biketoot #mastobikes
MESSAGE

# Since this is coming out of mail, we'll just fire and forget
HTTParty.post("#{ENV.fetch('BASE_URL', nil)}/api/v1/statuses", headers:, body: { status: }.to_json)
