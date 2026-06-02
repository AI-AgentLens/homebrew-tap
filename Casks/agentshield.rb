cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1189"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1189/agentshield_0.2.1189_darwin_amd64.tar.gz"
      sha256 "4af7d0ace2f2537c38e736c399ac0ffbc4dd5b068c182c320ce3bde40071ebef"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1189/agentshield_0.2.1189_darwin_arm64.tar.gz"
      sha256 "f03eb40f72106de9bc6fbe8eab10b70e0d31155e7490abe831919e79a5f3282b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1189/agentshield_0.2.1189_linux_amd64.tar.gz"
      sha256 "98b8b81206e650a9f67dc4464ee3669f1241d63f60181f9c6c29220c79692e3b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1189/agentshield_0.2.1189_linux_arm64.tar.gz"
      sha256 "a5da5c821b3c54f3691ea6755362622c983577ba96ff3924655403b99e9dd388"
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
