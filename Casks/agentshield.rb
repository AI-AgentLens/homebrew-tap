cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1408"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1408/agentshield_0.2.1408_darwin_amd64.tar.gz"
      sha256 "1c080e3900b2228d11597edf0891efea568de186872e9d35134dc47efe561430"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1408/agentshield_0.2.1408_darwin_arm64.tar.gz"
      sha256 "91c99d54c3f4e5850b76d233a9d8a46f7f70ebac620cb3f38178a161a6c1ddf5"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1408/agentshield_0.2.1408_linux_amd64.tar.gz"
      sha256 "e718b5c6db1b74f37460715c4bdddf1ede436885c711e45194f67500d8c46b45"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1408/agentshield_0.2.1408_linux_arm64.tar.gz"
      sha256 "b85a50e95fedaef429afb66a9327164b51a46c065c9b29e9fce1c6408bc99591"
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
