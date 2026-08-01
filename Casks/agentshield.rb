cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1768"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1768/agentshield_0.2.1768_darwin_amd64.tar.gz"
      sha256 "b00e778c8d6d578a46203c6beb9d4cfdc7eff876789dfa0152e08dcf65e1635e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1768/agentshield_0.2.1768_darwin_arm64.tar.gz"
      sha256 "c4a5c5bd0bf4ae1919f541d5cffec9cab6b3c865fa2e2191f2402d94c9a0fe8e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1768/agentshield_0.2.1768_linux_amd64.tar.gz"
      sha256 "a6c078668710e5166315e54834c477086e1e539a8be216ac674601daf683e20e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1768/agentshield_0.2.1768_linux_arm64.tar.gz"
      sha256 "c895758dd35b847e17351925d7951b461ab881b461817d5e9fa35c32788320a7"
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
