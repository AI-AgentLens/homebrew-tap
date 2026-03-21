class Agentshield < Formula
  desc "Local-first runtime security gateway for LLM agents"
  homepage "https://github.com/security-researcher-ca/AI_Agent_Shield"
  url "https://github.com/security-researcher-ca/AI_Agent_Shield.git", branch: "main"
  version "0.2.1"
  license "Apache-2.0"

  disable! date: "2026-03-21", because: "the cask should be used now instead", replacement_cask: "agentshield"
end
