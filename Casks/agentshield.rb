cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.779"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.779/agentshield_0.2.779_darwin_amd64.tar.gz"
      sha256 "ebcddd2fa44aab2f4784ef669d6dbecd433cc0bcc34303d9964522a19576a076"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.779/agentshield_0.2.779_darwin_arm64.tar.gz"
      sha256 "5e4662bc694f509f33df6bef19a53e89be597101528da218af38b020f5018d75"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.779/agentshield_0.2.779_linux_amd64.tar.gz"
      sha256 "772f26ddabc45202dba8920e98eb4b8297428dfeb593078ebb5368efe8a70ef5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.779/agentshield_0.2.779_linux_arm64.tar.gz"
      sha256 "2e60c02be0fb8a30695763683a80b92cc6aaa75cc315b09ffee2db444aecfffa"
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
