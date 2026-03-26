cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.59"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.59/agentshield_0.2.59_darwin_amd64.tar.gz"
      sha256 "e367c5edcd8c5080d36d68b94cdae644b68efa0b209c7598999c11dfdafbb7a7"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.59/agentshield_0.2.59_darwin_arm64.tar.gz"
      sha256 "53f658dc03bde0ba9fc131faf70cb658415c67b304dafcfe0fb3918814ab9550"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.59/agentshield_0.2.59_linux_amd64.tar.gz"
      sha256 "3a8406916b24dbcfe1b335ce4d72961ea4a3cf5c1a545c98a872f3011a5ab174"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.59/agentshield_0.2.59_linux_arm64.tar.gz"
      sha256 "a284a4ed456b3f40ec022aae9984e86ca8a3265b8354d2683b820218571d8728"
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
