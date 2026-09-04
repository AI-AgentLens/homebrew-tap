cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2040"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2040/agentshield_0.2.2040_darwin_amd64.tar.gz"
      sha256 "56c42dbdbd20cd2488bb32d4d6a163d5b9600fea0aa17d9be210d66f9dc2afa1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2040/agentshield_0.2.2040_darwin_arm64.tar.gz"
      sha256 "4fc87bc66cb8fa2de95f6b25ca67f44a829f8bfdbe125d63c0601a1f13240501"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2040/agentshield_0.2.2040_linux_amd64.tar.gz"
      sha256 "43e10b9acfdfe6fa59f55298478ec8717e64ced25b3314a28f37a51b2dc77d29"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2040/agentshield_0.2.2040_linux_arm64.tar.gz"
      sha256 "3639e99499db25c8fc1315a9bb1f39ec5484c405c4d90f8ce52fc7bfc4486d16"
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
