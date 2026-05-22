cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1075"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1075/agentshield_0.2.1075_darwin_amd64.tar.gz"
      sha256 "3f322029d827d65363d9b1a6a254685000e551d39d6233722936ca9bfa79329e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1075/agentshield_0.2.1075_darwin_arm64.tar.gz"
      sha256 "6499bcdc2f3ef012cd1393b5dfdc512619eb29db7ef1d26d531357dd46ca89f5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1075/agentshield_0.2.1075_linux_amd64.tar.gz"
      sha256 "a1e6f09e247c1705d9ef71370d766d45014d67b4c675c2b0b76c81a97af1cece"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1075/agentshield_0.2.1075_linux_arm64.tar.gz"
      sha256 "8ed0c942aa310bb5a827b6be6f09472e299a2839879ed6d1f9783ce8bf805ad0"
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
