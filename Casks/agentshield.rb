cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1181"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1181/agentshield_0.2.1181_darwin_amd64.tar.gz"
      sha256 "94d74079ce34ceb4e1412e1044a1339694046bd9dbad6cdbb6cd92c35552ecd4"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1181/agentshield_0.2.1181_darwin_arm64.tar.gz"
      sha256 "6fc35151166a29f0ac041f940faf8b07f5afd8761678d1c00b014db46ac4fd9d"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1181/agentshield_0.2.1181_linux_amd64.tar.gz"
      sha256 "885266361ac2697413d6e52f44889445b9706a08c8c11425888c308973a42d6e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1181/agentshield_0.2.1181_linux_arm64.tar.gz"
      sha256 "6b6ffe4fdb833c55f6bf686ba639b63370c3cde651c6c4d4774d782ae5f8c80a"
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
