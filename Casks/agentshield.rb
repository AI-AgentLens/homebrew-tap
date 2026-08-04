cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1785"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1785/agentshield_0.2.1785_darwin_amd64.tar.gz"
      sha256 "838b7b4a372c640ba33eb287d2344e190fa462a49109eefadaee124d56019c77"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1785/agentshield_0.2.1785_darwin_arm64.tar.gz"
      sha256 "72702c71c2b2b80a2dec8b88a3b913de03b8762ddf9b2058d9e3cbfb08fdc310"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1785/agentshield_0.2.1785_linux_amd64.tar.gz"
      sha256 "1f932eb4874ad39e2c63ad6a34635b7d6e657e60490df7b569e37a7f91317464"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1785/agentshield_0.2.1785_linux_arm64.tar.gz"
      sha256 "97605b91f4b4d72608471e3b6cf8b15c5db45d82c3f729f6ec1b95829fef0347"
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
