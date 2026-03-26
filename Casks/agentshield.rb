cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.16"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.16/agentshield_0.2.16_darwin_amd64.tar.gz"
      sha256 "74a73c301518609f118fd215b9d76c77f0fef3c48170518849f5e3a4721f3c62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.16/agentshield_0.2.16_darwin_arm64.tar.gz"
      sha256 "ee0f0b3162c46e101e8f9d3c597b12490d4a880c1040fb09ab54dc77a92d2b8e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.16/agentshield_0.2.16_linux_amd64.tar.gz"
      sha256 "3b864551c379f7a313d6c9ab78a5f8fc6ebc8e63df92dd44ad4a582a3be689a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.16/agentshield_0.2.16_linux_arm64.tar.gz"
      sha256 "c674443487ea1f996462ba50604ef9fb48ad45c7fbe7ddbce73ef810f1806a85"
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
