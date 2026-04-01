cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.287"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.287/agentshield_0.2.287_darwin_amd64.tar.gz"
      sha256 "bc97141e10d1ef0d4dadb5baf32637f70963d1475e684171b0caa2de30ba84b5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.287/agentshield_0.2.287_darwin_arm64.tar.gz"
      sha256 "f96fe9440e870c651ad4e10a12042834db7ceb852e2a9007bafda943ebc5babd"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.287/agentshield_0.2.287_linux_amd64.tar.gz"
      sha256 "b50d2bd14fe7872e662bb2391119ec33430fa0926e27fe697d84feddddc030e9"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.287/agentshield_0.2.287_linux_arm64.tar.gz"
      sha256 "8fbd7bcc6dc9e7a62589bcf238c5e2baa68c7bf75dec50c902986d4a26baeb05"
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
