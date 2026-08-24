cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1944"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1944/agentshield_0.2.1944_darwin_amd64.tar.gz"
      sha256 "dd895c40c390082ee6862d6086037899f1a089a54bc814c582c3d941870e441c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1944/agentshield_0.2.1944_darwin_arm64.tar.gz"
      sha256 "3754156f24a7c33aca631df08c09bd0e32832e7be40c5627001c463acaea34c9"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1944/agentshield_0.2.1944_linux_amd64.tar.gz"
      sha256 "3e7545d9af3a40c468011778cabbf1516aebe344cabe5dba79cf7fce0911b710"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1944/agentshield_0.2.1944_linux_arm64.tar.gz"
      sha256 "c312a52cc0ff7044c5cd3396166c6ed57b5732fa065ba6b2ec51912bb1ba5f6c"
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
