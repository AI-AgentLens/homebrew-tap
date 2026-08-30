cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1997"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1997/agentshield_0.2.1997_darwin_amd64.tar.gz"
      sha256 "6ce73340d1a3af179a80ed985e01cf461de0c2baf57e7118d7e72a83468f9c1a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1997/agentshield_0.2.1997_darwin_arm64.tar.gz"
      sha256 "b28048be50f5d4c38ed10b74cc3844beb8421de594850d8b61d6a947aa37641d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1997/agentshield_0.2.1997_linux_amd64.tar.gz"
      sha256 "df43c5480d4cd4440c9db9731a20611e3412df14c68f21f20b5d31cef6a42681"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1997/agentshield_0.2.1997_linux_arm64.tar.gz"
      sha256 "8984f379e371a9f987247b6d010bda25ca7e721e7eb6cb332855d1513e829090"
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
