cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1111"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1111/agentshield_0.2.1111_darwin_amd64.tar.gz"
      sha256 "a9abd0c1c4aff38d835066e8079ac4d7b46e1e7051414336780be53b49cf2abc"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1111/agentshield_0.2.1111_darwin_arm64.tar.gz"
      sha256 "1f6005956621fcc02e665bc4d6a3fd0bb7edb43713b45a4592027996375d8631"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1111/agentshield_0.2.1111_linux_amd64.tar.gz"
      sha256 "a01efaf8d5f85a4dbf129ab21cac4b9db2e6619b7838051993a4cd3abfcd5bde"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1111/agentshield_0.2.1111_linux_arm64.tar.gz"
      sha256 "88392e4d03947ce03a8dddc56c308bbfce5fc63c0fb8f65d895c605843b0de0c"
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
