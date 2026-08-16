cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1874"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1874/agentshield_0.2.1874_darwin_amd64.tar.gz"
      sha256 "5afe99ae16dfcf96ba4414c8e49fdbc26dae904e80fd8e11926c54d2cc3d1987"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1874/agentshield_0.2.1874_darwin_arm64.tar.gz"
      sha256 "f99c904f7b4e23d3c648c3373d38a45b1e2f4176a44525ccf73cdcf97494fa5c"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1874/agentshield_0.2.1874_linux_amd64.tar.gz"
      sha256 "50f7912483ee2551df43b06ec12fa2d4825af7cec5a9ae463570e48848e5fd3d"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1874/agentshield_0.2.1874_linux_arm64.tar.gz"
      sha256 "72ca43ce24de5f0061b70e81e5219166e1beb2064ebc67e083d3fc577e79e972"
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
