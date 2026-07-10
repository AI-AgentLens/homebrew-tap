cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1610"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1610/agentshield_0.2.1610_darwin_amd64.tar.gz"
      sha256 "edd13bf10ed459ae9da6277c75ca924882926b8e37d319b38de98b4fb30b238c"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1610/agentshield_0.2.1610_darwin_arm64.tar.gz"
      sha256 "811330d32443c4470d010c3c32e3a611a42e6db3553dc7712b69c43d98cabb16"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1610/agentshield_0.2.1610_linux_amd64.tar.gz"
      sha256 "dd942ea335a65a1ee7e13d7f77afae4644cc175c07c3451e14294cd9901ee56e"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1610/agentshield_0.2.1610_linux_arm64.tar.gz"
      sha256 "a5673da8262dcc01f8e8f42cce69a12fc1e64872ff5a3081b81e9230c649432c"
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
