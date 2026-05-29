cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1149"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1149/agentshield_0.2.1149_darwin_amd64.tar.gz"
      sha256 "f7b89e654b0fcc12665faa89d9889dd2014945b328036bf2431eeac0bf5b1b82"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1149/agentshield_0.2.1149_darwin_arm64.tar.gz"
      sha256 "c9c14d8ca6d66a419283604c5c88621f48da761b64771dd6a7de683e830336d8"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1149/agentshield_0.2.1149_linux_amd64.tar.gz"
      sha256 "848741028ab97fbe1c8bfc677808ddadd154ccdc94ac5b47afd70122a12305a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1149/agentshield_0.2.1149_linux_arm64.tar.gz"
      sha256 "2054fd33a434ba14a082de682a3af9203435dcecca546594afaf0ca58bfdb587"
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
