cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1496"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1496/agentshield_0.2.1496_darwin_amd64.tar.gz"
      sha256 "c9ce6e984b5c3a231818442593bd114b542a37c6cc1212cece32fb5341edd745"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1496/agentshield_0.2.1496_darwin_arm64.tar.gz"
      sha256 "965eb2b5cf02222832bca6d35e99910f18210b9d00687c2f1a2beba7522ce822"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1496/agentshield_0.2.1496_linux_amd64.tar.gz"
      sha256 "2f20acfe5dced43f94e75ede779005d26f13c904fad8a4d55bcfbae067dc0f20"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1496/agentshield_0.2.1496_linux_arm64.tar.gz"
      sha256 "ddc0971bac18a0a25a5ec684cd6ec585dcb4f4bb97689234d2454f3fe79283e7"
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
