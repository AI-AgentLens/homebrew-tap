cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.795"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.795/agentshield_0.2.795_darwin_amd64.tar.gz"
      sha256 "11fbf824ac98facbaf0a558ebb7e5bbfdcc8cd828c11514388f747e58568bc79"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.795/agentshield_0.2.795_darwin_arm64.tar.gz"
      sha256 "90122a19504d2645f4a1367ac55ca3020bba19bb7d38e37cf3ccd4c50ae81d6f"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.795/agentshield_0.2.795_linux_amd64.tar.gz"
      sha256 "f76a3969da0e3ec6b73e4b9f8a428ace8068053e3533769771fc258c3771105e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.795/agentshield_0.2.795_linux_arm64.tar.gz"
      sha256 "474d58535bc4f34b3259da02057911579f477e5785c1a7a3b678ef0847baf66e"
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
