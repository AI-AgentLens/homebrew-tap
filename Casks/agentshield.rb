cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2345"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2345/agentshield_0.2.2345_darwin_amd64.tar.gz"
      sha256 "b3f57a537a0460d694b9893b8f5cb5d681c708fda31979622eaaa57da8986a44"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2345/agentshield_0.2.2345_darwin_arm64.tar.gz"
      sha256 "0a0399bd774c8d2dfe44625b16beb221f7729f8820e7b64f79eb2f33afe9c9dc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2345/agentshield_0.2.2345_linux_amd64.tar.gz"
      sha256 "6f69bb0168f756aef1dab7177b263c096486d190830b33f096def54d650de394"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2345/agentshield_0.2.2345_linux_arm64.tar.gz"
      sha256 "1160ffcd546822129c394816e874d4f760447a3123c13fe5a99ba7c086c2f8c4"
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
