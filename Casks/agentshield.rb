cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1953"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1953/agentshield_0.2.1953_darwin_amd64.tar.gz"
      sha256 "80805d87cd50ec53ddcc00d0b8ebb8e0a1faca2ee1c32bb823866a0b304dce89"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1953/agentshield_0.2.1953_darwin_arm64.tar.gz"
      sha256 "572d72a35a7f36f47e19e1f7b6036dba9a27e4e3c3c78186ff6512f54aed0ba4"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1953/agentshield_0.2.1953_linux_amd64.tar.gz"
      sha256 "91200061db5c3ce3f67217b10b15a4d5ca6dfdd25e7316ebf4f3533f2c63ae62"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1953/agentshield_0.2.1953_linux_arm64.tar.gz"
      sha256 "e72b89736cbb2d1e514090d2dd5cbf7f60a5a77776d2f61e1b0d68a1536014cf"
    end
  end

  # Stop the heartbeat daemon before upgrading so the old binary doesn't keep
  # running as a zombie after brew replaces it.
  preflight do
    if OS.mac?
      plist = File.expand_path("~/Library/LaunchAgents/com.aiagentlens.agentshield.plist")
      if File.exist?(plist)
        system_command "/bin/launchctl", args: ["bootout", "gui/#{Process.uid}/com.aiagentlens.agentshield"], print_stderr: false
        File.delete(plist) if File.exist?(plist)
      end
    end
  end

  postflight do
    if OS.mac?
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentshield"]
      system_command "/usr/bin/xattr", args: ["-dr", "com.apple.quarantine", "#{staged_path}/agentcompliance"]
    end
  end

  uninstall launchctl: "com.aiagentlens.agentshield",
            delete:    "~/Library/LaunchAgents/com.aiagentlens.agentshield.plist"

  caveats <<~EOS
    Two tools installed:
      agentshield      — Runtime security gateway for AI agents
      agentcompliance  — Local compliance scanner (semgrep-based)

    Quick start:
      agentshield setup
      agentshield login
  EOS
end
