cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2496"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2496/agentshield_0.2.2496_darwin_amd64.tar.gz"
      sha256 "a865005bf15c7686f51708a7029cf221f8681a1aca56d69617c966ff1c73b98a"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2496/agentshield_0.2.2496_darwin_arm64.tar.gz"
      sha256 "659c8ef3d374e3ecf5a42b71ac26752df6dcb472dcbebe16c1c27dfd5356719b"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2496/agentshield_0.2.2496_linux_amd64.tar.gz"
      sha256 "e1922074c503ad2235e91edcfdffb2060e44d91a76095249c56bfbc02521a747"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2496/agentshield_0.2.2496_linux_arm64.tar.gz"
      sha256 "6827f26f7c58460bab0bcc3cb476a0a224e20e77ee486a22cef4b9dde1f22119"
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
