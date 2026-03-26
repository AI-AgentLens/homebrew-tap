cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.64"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.64/agentshield_0.2.64_darwin_amd64.tar.gz"
      sha256 "3066f7405737342fd49eb0f53ac5ec58b38d65467da076f9c387f8010dbb81d6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.64/agentshield_0.2.64_darwin_arm64.tar.gz"
      sha256 "45b231ec45d92f61cf80855b13dec30abbe3c25e5a65ffc9604c77726620dc9e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.64/agentshield_0.2.64_linux_amd64.tar.gz"
      sha256 "b21a82749e8ff2ba3d56659dd3593d6ccd9cf3a2627fb5d1582edfe7c90a2dfd"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.64/agentshield_0.2.64_linux_arm64.tar.gz"
      sha256 "8e1e4c09ed2cd809629e28b3225bb3a39bbf97a589c9e24e4301c5af7cfa34bc"
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
