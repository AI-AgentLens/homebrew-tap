cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.1187"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1187/agentshield_0.2.1187_darwin_amd64.tar.gz"
      sha256 "232bf9f6abd2d1bcb62ff4a259c1defdfdad1665aaf5de4ef5f80dd9a27c3330"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1187/agentshield_0.2.1187_darwin_arm64.tar.gz"
      sha256 "64dc48be2db7cc92ab7772b19f4caa96ce7df0024392dd87b3197aa17029392a"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.1187/agentshield_0.2.1187_linux_amd64.tar.gz"
      sha256 "8e456740a964b4d3225c257a135854f3474d0d93f1728abe35597c0939e4b9a3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.1187/agentshield_0.2.1187_linux_arm64.tar.gz"
      sha256 "280f10ef96542dd2ba06812cae2e8110ee691524c1e13cc533afafbf648754a8"
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
