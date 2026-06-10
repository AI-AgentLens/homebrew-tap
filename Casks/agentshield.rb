cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1272"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1272/agentshield_0.2.1272_darwin_amd64.tar.gz"
      sha256 "5a9774acec7ef0de4dd7fd1d68f9b0c96ab4a315f4bce916102d85f543f9c338"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1272/agentshield_0.2.1272_darwin_arm64.tar.gz"
      sha256 "03af124f3822fadb9a1c0cc6b553f303a4570070b2f6f3a1dae48be06b4feaa2"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1272/agentshield_0.2.1272_linux_amd64.tar.gz"
      sha256 "2aa838a471459e380f9b33cf3182b4a68e2930d4bafb6191ab13616a92d67e37"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1272/agentshield_0.2.1272_linux_arm64.tar.gz"
      sha256 "f34afbb5bfe2586b8876d2579cd5db41649c93871db0032c8c39b71be2bebd91"
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
