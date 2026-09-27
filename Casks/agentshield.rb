cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2270"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2270/agentshield_0.2.2270_darwin_amd64.tar.gz"
      sha256 "36a66d6d8d245497aa96dd267cd3b452c038d7f6db99755c597c930036539a2b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2270/agentshield_0.2.2270_darwin_arm64.tar.gz"
      sha256 "847aac5ad6e8d989d8ab381d48211baf1575b12f671c4686922224a391bfe74b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2270/agentshield_0.2.2270_linux_amd64.tar.gz"
      sha256 "e37a82188671eb1a2e6ebb7911ed29242e50d42532b30ee91e90ea64bb0d3b4a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2270/agentshield_0.2.2270_linux_arm64.tar.gz"
      sha256 "887d3cdfe48239f5b0a6af71a8c465b9b9094ae9b49b24328f77c9d19f5b9369"
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
