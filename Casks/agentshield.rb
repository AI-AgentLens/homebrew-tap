cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.933"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.933/agentshield_0.2.933_darwin_amd64.tar.gz"
      sha256 "5cf970cc978ddd6ff9599e1984be7b1b05ba0a61ebc264f9f84e276e537ede79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.933/agentshield_0.2.933_darwin_arm64.tar.gz"
      sha256 "15021959dd83ce83002a5176971e9d58dd4f5daec011ee2fa74f80fe1f2e361f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.933/agentshield_0.2.933_linux_amd64.tar.gz"
      sha256 "ff7ebd4250364bb8a087de834718d6a038b03e22d59a84128dc5aa715adc2db1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.933/agentshield_0.2.933_linux_arm64.tar.gz"
      sha256 "3531715131b03bfc0155940cf08d3cd1a8189d0ab2490e6ea14a0cbcb9e921d1"
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
