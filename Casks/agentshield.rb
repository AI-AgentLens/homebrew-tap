cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1315"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1315/agentshield_0.2.1315_darwin_amd64.tar.gz"
      sha256 "6bd24370428ec3dbc8a9668febb0b70fa489483f38805e3c38ca0fb63bef6ec2"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1315/agentshield_0.2.1315_darwin_arm64.tar.gz"
      sha256 "9fbb919fad1e356aa23f5760047b8d3060e2bf4e5c7f0e7c85976b2905565c4e"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1315/agentshield_0.2.1315_linux_amd64.tar.gz"
      sha256 "f1b9274ab5728f9ee2a85800b408ea5312e37b16f089ca6a83da796cda0e4642"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1315/agentshield_0.2.1315_linux_arm64.tar.gz"
      sha256 "20a3c5ac552f0faddf9d6d3d51c61cf18cd2d1260c800e7ff4e8852b3376abdd"
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
