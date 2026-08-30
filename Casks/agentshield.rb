cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1991"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1991/agentshield_0.2.1991_darwin_amd64.tar.gz"
      sha256 "c67bef5d9a85909a57ed40c21edd0a016c98e158a4d74ded10fcb9b355ff07be"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1991/agentshield_0.2.1991_darwin_arm64.tar.gz"
      sha256 "65ca6287cef0da4464a9ad70d7641aeb5d41eb90febbdcd408a6837080acea30"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1991/agentshield_0.2.1991_linux_amd64.tar.gz"
      sha256 "d8a1163c03a6fd2c1a2824b29adac8ce97f2391a0bc0c9261a53ec207cfb8ff2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1991/agentshield_0.2.1991_linux_arm64.tar.gz"
      sha256 "96d471fd88345397f17a9a81166363ca8838f9ca0c4a31b2881852eb833b3303"
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
