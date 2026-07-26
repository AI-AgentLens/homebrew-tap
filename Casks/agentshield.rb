cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1732"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1732/agentshield_0.2.1732_darwin_amd64.tar.gz"
      sha256 "47425631f7373c54b463a5e4dbb379fe739c1038118336ad8ae2a18a76863afe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1732/agentshield_0.2.1732_darwin_arm64.tar.gz"
      sha256 "be2d2592133bbbc8119f79e84809ca8c5a316b479c017002e47dec6c4fe2e6df"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1732/agentshield_0.2.1732_linux_amd64.tar.gz"
      sha256 "a190f9aebc744b0f261a7737964413afc73dcda73bb4cea5b7259ba146ad3b46"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1732/agentshield_0.2.1732_linux_arm64.tar.gz"
      sha256 "fdf7db4dedec2790bf68eaf2bfc8c356249c581a0cd149299403c1772c17f30a"
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
