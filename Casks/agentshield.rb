cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2386"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2386/agentshield_0.2.2386_darwin_amd64.tar.gz"
      sha256 "b6505d38775ce66914f21e7203ce6d95557977aec6521eba9f8bc2c7a3c05cce"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2386/agentshield_0.2.2386_darwin_arm64.tar.gz"
      sha256 "e07ccb50c949d019fca37a8e9ca891e2f187502b97829174563d413a535d6624"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2386/agentshield_0.2.2386_linux_amd64.tar.gz"
      sha256 "33fbf4d120521140d894d0bfaa295768397d24f0444120262e4d2793dda48594"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2386/agentshield_0.2.2386_linux_arm64.tar.gz"
      sha256 "3c6a178bde47f2bdfff6f28b41921e490c6d6e5c706eced80e7e6c6ba05c4feb"
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
