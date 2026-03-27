cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.111"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.111/agentshield_0.2.111_darwin_amd64.tar.gz"
      sha256 "a8a08eaf0637b45413fe605e9b7e209407665e17593ec183b7687f9621328fd1"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.111/agentshield_0.2.111_darwin_arm64.tar.gz"
      sha256 "f9c696afc3bd3ae2676e6a879286cd9a7ea7d86f16a2c68759d99cd86ff252ec"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.111/agentshield_0.2.111_linux_amd64.tar.gz"
      sha256 "d0057a8d598251904cc1192f5f535f60fc5ac4b7dca45a956bb8b5fc36d71940"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.111/agentshield_0.2.111_linux_arm64.tar.gz"
      sha256 "9d15106fdb48fbbc66b2901a1803565f79b036aa6491c46cc80fe11103693938"
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
