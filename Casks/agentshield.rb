cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.2438"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2438/agentshield_0.2.2438_darwin_amd64.tar.gz"
      sha256 "419647f1a77a556043e66b48ad888731600a15e9473fdf667ecbae9d15e32cc5"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2438/agentshield_0.2.2438_darwin_arm64.tar.gz"
      sha256 "6ab1a6d51340c2a7c159ded7e626ab88f145a625e3ddc8c8de9588c9749a46bc"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.2438/agentshield_0.2.2438_linux_amd64.tar.gz"
      sha256 "ee468d712cf639ff33e5d8398dd84f371182d1e948e90747e5604f00da2290fe"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.2438/agentshield_0.2.2438_linux_arm64.tar.gz"
      sha256 "d142330969f159e7af174f68ffc6d0b67b49efebc44a06611e8383dd10e60f5a"
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
