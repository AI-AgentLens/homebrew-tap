cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.473"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.473/agentshield_0.2.473_darwin_amd64.tar.gz"
      sha256 "ec81a5690ac9f644c08c2874df79281b4d192590eae2b52708c289f12a26922b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.473/agentshield_0.2.473_darwin_arm64.tar.gz"
      sha256 "cc062420fa808fa4d236afa9fa3bbc60f8a373932e73253674c84a2295a0b9d5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.473/agentshield_0.2.473_linux_amd64.tar.gz"
      sha256 "dd27765b38cc8447738cace7f7faec31b3734949cf92b562198ec19fbf289ec5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.473/agentshield_0.2.473_linux_arm64.tar.gz"
      sha256 "ff173f7db12358e325105f77cc30a639b13c31f6a237ef1104033a8f0d19a5aa"
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
