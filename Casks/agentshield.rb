cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.140"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.140/agentshield_0.2.140_darwin_amd64.tar.gz"
      sha256 "4e60f4b454d5f4574aa88bfe088bb7605291f63e0fcc5c50d2401ca5a42a0bd8"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.140/agentshield_0.2.140_darwin_arm64.tar.gz"
      sha256 "3e66c983adc1ec743ee0cfa431a398f23511bd6ea031afa708599ea9633394d0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.140/agentshield_0.2.140_linux_amd64.tar.gz"
      sha256 "cdaf162c6b2e1deebbb26fcd9271b56b9795436c186fde864f10be071effe19e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.140/agentshield_0.2.140_linux_arm64.tar.gz"
      sha256 "ba0917485384266bdbc90fddd3ecd09df172ac9f111c7c708283ffa79c8004ce"
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
