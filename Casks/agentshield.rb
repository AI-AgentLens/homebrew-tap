cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.861"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.861/agentshield_0.2.861_darwin_amd64.tar.gz"
      sha256 "102fda16e2e03574d098fdc704f45a2c5ab91fe3347f7421641966f16834849d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.861/agentshield_0.2.861_darwin_arm64.tar.gz"
      sha256 "6e64fd0f426722a61860abd68e829ebf114894dbdb4bf9713c286bef53f0eba0"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.861/agentshield_0.2.861_linux_amd64.tar.gz"
      sha256 "9f1d13c4e060c381bdcdeae915c6634072639a28104181821d2f5b102684bd5b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.861/agentshield_0.2.861_linux_arm64.tar.gz"
      sha256 "d21a74ce0294d62de09a785ca8d403cc9fbda4d5e2176460a876740837e38b8a"
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
