cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.707"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.707/agentshield_0.2.707_darwin_amd64.tar.gz"
      sha256 "967e609fd02807c87d611794b7268cdcc9632ca802a145102b2470498d2683cb"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.707/agentshield_0.2.707_darwin_arm64.tar.gz"
      sha256 "432f4f9a0aa4969d18ab5acedf6ad38fee52fc516f900c0fff83f64ba9f84175"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.707/agentshield_0.2.707_linux_amd64.tar.gz"
      sha256 "2efa0b899bbc071cceea18d116ec6183745b0180c4b23aea38ee324d8c08e45f"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.707/agentshield_0.2.707_linux_arm64.tar.gz"
      sha256 "87ac2010e40ac7708320c396480a0fc486618e08e2b8e383c63f85dfacff0666"
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
