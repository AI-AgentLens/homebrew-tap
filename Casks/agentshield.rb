cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2405"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2405/agentshield_0.2.2405_darwin_amd64.tar.gz"
      sha256 "c2bb1181ed9f18c4f35f925406f2e8c21e143dee70408fc18dfe774b0c110c53"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2405/agentshield_0.2.2405_darwin_arm64.tar.gz"
      sha256 "afcde4b0322a46370fbeedc30008de8193b907b521860f58f976ea7c0ddc14d9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2405/agentshield_0.2.2405_linux_amd64.tar.gz"
      sha256 "0e6e4cce1e12d80f4e5142145752897c342ffd56a50aacebd496aff0a0ceb097"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2405/agentshield_0.2.2405_linux_arm64.tar.gz"
      sha256 "669ed68206f2b7bdf2a66449bcc7f1204d77d3c58509e0fd86e74d006f982f27"
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
