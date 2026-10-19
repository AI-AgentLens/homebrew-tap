cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2474"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2474/agentshield_0.2.2474_darwin_amd64.tar.gz"
      sha256 "aa0fdfbd2a8c5515e1b504524c811b1218e96cba7b86cfe9d1a7bb7d5d95ffaf"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2474/agentshield_0.2.2474_darwin_arm64.tar.gz"
      sha256 "843223e67a8028566130db620b9be0dff8d77381f6646e916d5211302851019c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2474/agentshield_0.2.2474_linux_amd64.tar.gz"
      sha256 "552790299db754b761838ff39bc4f786739d1aa090f0626c676dd841d64fd5e6"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2474/agentshield_0.2.2474_linux_arm64.tar.gz"
      sha256 "0413a734f197ab0a7dafb505dd889a97efe48f64b6fb163afdd7769451c9ab85"
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
