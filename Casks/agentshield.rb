cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.570"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.570/agentshield_0.2.570_darwin_amd64.tar.gz"
      sha256 "0f11778b45e66e9ed3286168bdd86cc23f506a81549ec8be82590e143875b5f2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.570/agentshield_0.2.570_darwin_arm64.tar.gz"
      sha256 "31e5989d61818c918f1ae1772ab3bc4e77127b4976a282533a6e13e42c92642a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.570/agentshield_0.2.570_linux_amd64.tar.gz"
      sha256 "6f18277562fe930bd152eb364e517eef889b93e8fa6c477297dd82467f8a241c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.570/agentshield_0.2.570_linux_arm64.tar.gz"
      sha256 "2b229731eef58d67555437c80b4b4ee4acc56634c3ca021b23928f20bf921802"
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
