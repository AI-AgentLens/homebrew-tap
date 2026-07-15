cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1649"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1649/agentshield_0.2.1649_darwin_amd64.tar.gz"
      sha256 "11cedd3fee4ac99267d2df8525807953d64a76a2bf4836f44c3c9f012928734d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1649/agentshield_0.2.1649_darwin_arm64.tar.gz"
      sha256 "a01c5621bd6c8b07681cd68ddfdafbf74cd9799414e244c54042e01ea3feed04"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1649/agentshield_0.2.1649_linux_amd64.tar.gz"
      sha256 "7c17975fe52b4eeab647f632ba809bbe02b030e4cf9e3fca3915dafdabac5ece"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1649/agentshield_0.2.1649_linux_arm64.tar.gz"
      sha256 "094578e087eac35de0f09a864fc4906fe9372302d5f052736c738c7122e53053"
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
