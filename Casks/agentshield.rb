cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.641"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.641/agentshield_0.2.641_darwin_amd64.tar.gz"
      sha256 "2b3c74f242a996bf561349fe6a82d74c393ad792766384979b32a490c2456add"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.641/agentshield_0.2.641_darwin_arm64.tar.gz"
      sha256 "0ae86a9cd3645b4de8ad3d6b89ea18a01db3824cfbdb95833f15a2e9154d807e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.641/agentshield_0.2.641_linux_amd64.tar.gz"
      sha256 "3c054a99b7b5a4f7f1ae25d5f9f3564c02242f39cd6e02e01aaaf8edd7159bf5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.641/agentshield_0.2.641_linux_arm64.tar.gz"
      sha256 "e0197719131931381c08be7c4184f99145a012b47553d31fa52a6d49f2cb3dcc"
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
