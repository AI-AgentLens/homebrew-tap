cask "agentshield" do
  name "agentshield"
  desc "Runtime security gateway and compliance scanner for LLM agents"
  homepage "https://aiagentlens.com"
  version "0.2.642"

  livecheck do
    skip "Auto-updated by CI on release."
  end

  binary "agentshield"
  binary "agentcompliance"

  on_macos do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.642/agentshield_0.2.642_darwin_amd64.tar.gz"
      sha256 "fe91b45c3151e9c68931434a8fa76efd64932b6e713f9d7b98362bccd40d07e3"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.642/agentshield_0.2.642_darwin_arm64.tar.gz"
      sha256 "a35688c79ece29f47e22100952cd99212219a533186b03a6c51a3eb8384d3dc6"
    end
  end

  on_linux do
    on_intel do
      url "https://aiagentlens.com/releases/v0.2.642/agentshield_0.2.642_linux_amd64.tar.gz"
      sha256 "2ce3c812d7c0d7c12cb8ffce41c64fc551d9adf840b9340c0c25deedd0fa646b"
    end
    on_arm do
      url "https://aiagentlens.com/releases/v0.2.642/agentshield_0.2.642_linux_arm64.tar.gz"
      sha256 "fe02ad7758a427aabbb5f1bfdba53819ba9525e36d7bb77174102e5fa6f8193b"
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
